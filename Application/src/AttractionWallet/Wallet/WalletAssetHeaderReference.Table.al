table 6150933 "NPR WalletAssetHeaderReference"
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
        field(10; LinkToTableId; Integer)
        {
            Caption = 'Link To Table Id';
            DataClassification = CustomerContent;
        }
        field(11; LinkToSystemId; Guid)
        {
            Caption = 'Link To System Id';
            DataClassification = CustomerContent;
        }

        field(12; LinkToReference; Text[100])
        {
            Caption = 'Link To Reference';
            DataClassification = CustomerContent;
        }

        field(20; WalletHeaderEntryNo; Integer)
        {
            Caption = 'Wallet Header Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR WalletAssetHeader"."EntryNo";
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
            TableRelation = "NPR WalletAssetHeaderReference"."EntryNo";
        }

    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
        key(Key2; LinkToTableId, LinkToReference, SupersededBy)
        {
            Clustered = false;
        }

        key(Key3; LinkToTableId, LinkToSystemId)
        {
            Clustered = false;
        }
        key(Key4; WalletHeaderEntryNo, SupersededBy, LinkToTableId, LinkToReference)
        {
            Clustered = false;
        }

        key(Key5; LinkToReference, SupersededBy)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; LinkToReference)
        {
        }
    }

}