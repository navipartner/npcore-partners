query 6014491 "NPR FindAttractionWallets"
{
    QueryType = Normal;


    elements
    {
        dataitem(WalletAssetHeaderReference; "NPR WalletAssetHeaderReference")
        {
            column(ReferenceNumber; LinkToReference)
            {
            }
            column(LinkToTableId; LinkToTableId)
            {
            }
            column(ExpirationDate; ExpirationDate)
            {
            }

            column(Count)
            {
                // aggregate column to trigger the select distinct
                Method = Count;
            }
            dataitem(WalletHeader; "NPR WalletAssetHeader")
            {
                DataItemLink = EntryNo = WalletAssetHeaderReference.WalletHeaderEntryNo;

                dataitem(WalletAssets; "NPR WalletAssetLine")
                {
                    DataItemLink = TransactionId = WalletHeader.TransactionId;
                    DataItemTableFilter = Type = CONST(Wallet);

                    dataitem(Wallet; "NPR AttractionWallet")
                    {
                        DataItemLink = SystemId = WalletAssets.LineTypeSystemId;

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
                    }
                }
            }
        }
    }
}