query 6014499 "NPR AttractionWalletExtRef"
{
    elements
    {
        dataitem(AttractionWalletExtRef; "NPR AttractionWalletExtRef")
        {
            column(ExternalReference; ExternalReference)
            {
            }
            column(WalletEntryNo; WalletEntryNo)
            {
            }
            column(BlockedAt; BlockedAt)
            {
            }
            column(ExpiresAt; ExpiresAt)
            {
            }

            dataitem(AttractionWallet; "NPR AttractionWallet")
            {
                DataItemLink = EntryNo = AttractionWalletExtRef.WalletEntryNo;

                column(WalletExpirationDate; ExpirationDate)
                {
                }
                column(ReferenceNumber; ReferenceNumber)
                {
                }
                column(Description; Description)
                {
                }
            }
        }
    }
}