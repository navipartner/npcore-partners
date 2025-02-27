query 6014493 "NPR AttractionWalletAssetHist"
{
    QueryType = Normal;
    OrderBy = ascending(AssetEntryNo, AssetReferenceEntryNo);

    elements
    {
        dataitem(Asset; "NPR WalletAssetLine")
        {
            column(AssetEntryNo; EntryNo)
            {
            }
            column("AssetType"; "Type")
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

            dataitem(AssetReference; "NPR WalletAssetLineReference")
            {
                DataItemLink = WalletAssetLineEntryNo = Asset.EntryNo;
                column(AssetReferenceEntryNo; EntryNo)
                {
                }
                column(AssetReferenceExpirationDate; ExpirationDate)
                {
                }

                column(AssetReferenceSupersededByEntryNo; SupersededBy)
                {
                }
                column(AssetReferenceCreatedAt; SystemCreatedAt)
                {
                }
                column(AssetReferenceModifiedAt; SystemModifiedAt)
                {
                }


                dataitem(Wallet; "NPR AttractionWallet")
                {
                    DataItemLink = EntryNo = AssetReference.WalletEntryNo;
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
                    column(WalletCreatedAt; SystemCreatedAt)
                    {
                    }
                    column(WalletModifiedAt; SystemModifiedAt)
                    {
                    }
                }
            }
        }
    }


}