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