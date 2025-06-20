query 6014505 "NPR APIV1 PBI AttrWalletExtRef"
{
    Access = Internal;
    QueryType = API;
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'attractionWalletExternalReference';
    EntitySetName = 'attractionWalletExternalReferences';
    Caption = 'AttractionWalletExternalReferences', Locked = true;

    elements
    {
        dataitem(AttractionWalletExtRef; "NPR AttractionWalletExtRef")
        {
            column(externalReference; ExternalReference)
            {
            }
            column(walletEntryNo; WalletEntryNo)
            {
            }
            column(blockedAt; BlockedAt)
            {
            }
            column(expiresAt; ExpiresAt)
            {
            }

            dataitem(AttractionWallet; "NPR AttractionWallet")
            {
                DataItemLink = EntryNo = AttractionWalletExtRef.WalletEntryNo;

                column(walletExpirationDate; ExpirationDate)
                {
                }
                column(referenceNumber; ReferenceNumber)
                {
                }
                column(description; Description)
                {
                }
            }
        }
    }
}