query 6014490 "NPR AttractionWalletAssets"
{
    QueryType = Normal;


    elements
    {
        dataitem(Wallet; "NPR AttractionWallet")
        {

            column(WalletEntryNo; EntryNo)
            {
            }
            column(WalletReferenceNumber; ReferenceNumber)
            {
            }
            column(WalletSystemId; SystemId)
            {
            }
            column(WalletDescription; Description)
            {
            }
            column(WalletExpirationDate; ExpirationDate)
            {
            }
            column(WalletLastPrintAt; LastPrintAt)
            {
            }
            column(WalletPrintCount; PrintCount)
            {
            }

            dataitem(AssetReference; "NPR WalletAssetLineReference")
            {
                DataItemLink = WalletEntryNo = Wallet.EntryNo;

                dataitem(Asset; "NPR WalletAssetLine")
                {
                    DataItemLink = EntryNo = AssetReference.WalletAssetLineEntryNo;

                    column(AssetEntryNo; EntryNo)
                    {
                    }
                    column("AssetType"; "Type")
                    {
                    }
                    column(AssetItemNo; ItemNo)
                    {
                    }
                    column(AssetDescription; Description)
                    {
                    }
                    column(AssetSystemId; LineTypeSystemId)
                    {
                    }
                    column(AssetReferenceNumber; LineTypeReference)
                    {
                    }
                    column(AssetTransactionId; TransactionId)
                    {
                    }
                }
            }
        }
    }
}