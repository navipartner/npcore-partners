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
            column(Count)
            {
                // aggregate column to trigger the select distinct
                Method = Count;
            }
            dataitem(AssetReference; "NPR WalletAssetLineReference")
            {
                DataItemLink = WalletEntryNo = Wallet.EntryNo;

                column(SupersededByEntryNo; SupersededBy)
                { // will be non-zero if this line has been superseded. Meaning the asset is no longer in this wallet because it was added to a different wallet
                }
                column(AssetExpirationDate; ExpirationDate)
                {
                }
                dataitem(Asset; "NPR WalletAssetLine")
                {
                    DataItemLink = EntryNo = AssetReference.WalletAssetLineEntryNo;
                    DataItemTableFilter = Type = FILTER(<> Wallet);

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
                    column(SystemId; SystemId)
                    {
                    }
                }
            }
        }
    }
}