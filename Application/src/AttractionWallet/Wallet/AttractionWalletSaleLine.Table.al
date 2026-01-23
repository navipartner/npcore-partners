table 6150968 "NPR AttractionWalletSaleLine"
{
    Access = Internal;
    DataClassification = ToBeClassified;
    fields
    {
        field(1; SaleHeaderSystemId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Sale Header System Id';
        }

        field(2; LineNumber; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Number';
        }
        field(3; WalletNumber; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Number';
        }
        field(4; SaleLineId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Line Id';
        }

        field(10; ActionType; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Action Type';
            OptionMembers = CREATE,REVOKE,REVOKE_AND_REMOVE_HOLDER;
            OptionCaption = 'Create,Revoke,Revoke and Remove from Holder';
        }

        field(11; AssetTableId; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Asset Table Id';
        }

        field(12; AssetSystemId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Asset System Id';
        }

    }

    keys
    {
        key(Key1; SaleHeaderSystemId, LineNumber, WalletNumber)
        {
            Clustered = true;
        }

        key(Key2; SaleHeaderSystemId, WalletNumber, LineNumber)
        {
            Clustered = false;
        }
    }

}