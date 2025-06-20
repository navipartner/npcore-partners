query 6014504 "NPR APIV1 PBI AttrWltAssets"
{
    Access = Internal;
    QueryType = API;
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'attractionWalletAsset';
    EntitySetName = 'attractionWalletAssets';
    Caption = 'AttractionWalletAssets', locked = true;

    elements
    {
        dataitem(Wallet; "NPR AttractionWallet")
        {

            column(walletEntryNo; EntryNo)
            {
            }
            column(walletReferenceNumber; ReferenceNumber)
            {
            }
            column(walletSystemId; SystemId)
            {
            }
            column(walletDescription; Description)
            {
            }
            column(walletExpirationDate; ExpirationDate)
            {
            }
            column(walletLastPrintAt; LastPrintAt)
            {
            }
            column(walletPrintCount; PrintCount)
            {
            }
            column(count)
            {
                // aggregate column to trigger the select distinct
                Method = Count;
            }
            dataitem(AssetReference; "NPR WalletAssetLineReference")
            {
                DataItemLink = WalletEntryNo = Wallet.EntryNo;

                column(supersededByEntryNo; SupersededBy)
                { // will be non-zero if this line has been superseded. Meaning the asset is no longer in this wallet because it was added to a different wallet
                }
                column(assetExpirationDate; ExpirationDate)
                {
                }
                dataitem(Asset; "NPR WalletAssetLine")
                {
                    DataItemLink = EntryNo = AssetReference.WalletAssetLineEntryNo;
                    DataItemTableFilter = Type = FILTER(<> Wallet);

                    column(assetEntryNo; EntryNo)
                    {
                    }
                    column("assetType"; "Type")
                    {
                    }
                    column(assetItemNo; ItemNo)
                    {
                    }
                    column(assetDescription; Description)
                    {
                    }
                    column(assetSystemId; LineTypeSystemId)
                    {
                    }
                    column(assetReferenceNumber; LineTypeReference)
                    {
                    }
                    column(assetTransactionId; TransactionId)
                    {
                    }
                    column(systemId; SystemId)
                    {
                    }
                }
            }
        }
    }
}