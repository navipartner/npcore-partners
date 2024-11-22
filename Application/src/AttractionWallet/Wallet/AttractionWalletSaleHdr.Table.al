table 6150967 "NPR AttractionWalletSaleHdr"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; SaleHeaderSystemId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Sale Header System Id';
        }

        field(2; WalletNumber; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Number';
        }

        field(10; Name; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(20; ReferenceNumber; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Reference Number';

            trigger OnValidate()
            var
                Wallet: Record "NPR AttractionWallet";
            begin
                Wallet.Get(ReferenceNumber); // Hard fail on invalid reference number

                if (Wallet.Description <> '') then
                    Name := Wallet.Description;

            end;
        }
        field(40; WalletEntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Wallet Entry No';
        }
    }

    keys
    {
        key(Key1; SaleHeaderSystemId, WalletNumber)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }



}