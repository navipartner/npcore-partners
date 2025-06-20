query 6014503 "NPR APIV1 PBI POSEntrSLinAddOn"
{
    Access = Internal;
    QueryType = API;
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'posSalesBundle';
    EntitySetName = 'posSalesBundles';
    Caption = 'posSalesBundles', Locked = true;


    elements
    {
        dataitem(NpIa_POSEntrySaleLineAddOn; "NPR NpIa POSEntrySaleLineAddOn")
        {
            column(posEntrySaleLineId; POSEntrySaleLineId)
            {
            }
            column(lineNo; PosEntrySaleLineNo)
            {
            }
            column(appliesToSaleLineId; AppliesToSaleLineId)
            {
            }
            column(addOnNo; AddOnNo)
            {
            }
            column(addOnLineNo; AddOnLineNo)
            {
            }
            column(addToWallet; AddToWallet)
            {
            }
            column(addOnItemNo; AddOnItemNo)
            {
            }
            dataitem(NpIa_POSEntryLineBundleId; "NPR NpIa POSEntryLineBundleId")
            {
                DataItemLink = POSEntrySaleLineId = NpIa_POSEntrySaleLineAddOn.AppliesToSaleLineId;
                SqlJoinType = LeftOuterJoin;
                column(bundleSequence; Bundle)
                {
                }
                column(referenceNumber; ReferenceNumber)
                {
                }
                dataitem(NpIaPOSEntryLineBndlAsset; "NPR NpIa POSEntryLineBndlAsset")
                {
                    DataItemLink = POSEntrySaleLineId = NpIa_POSEntrySaleLineAddOn.POSEntrySaleLineId,
                                   Bundle = NpIa_POSEntryLineBundleId.Bundle;
                    SqlJoinType = LeftOuterJoin;

                    column(assetTableId; AssetTableId)
                    {
                    }
                    column(assetSystemId; AssetSystemId)
                    {
                    }
                }
            }
        }
    }
}