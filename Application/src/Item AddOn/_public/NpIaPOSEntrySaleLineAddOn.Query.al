query 6014497 "NPR NpIa POSEntrySaleLineAddOn"
{
    elements
    {
        dataitem(NpIa_POSEntrySaleLineAddOn; "NPR NpIa POSEntrySaleLineAddOn")
        {
            column(POSEntrySaleLineId; POSEntrySaleLineId)
            {
            }
            column(LineNo; PosEntrySaleLineNo)
            {
            }
            column(AppliesToSaleLineId; AppliesToSaleLineId)
            {
            }
            column(AddOnNo; AddOnNo)
            {
            }
            column(AddOnLineNo; AddOnLineNo)
            {
            }
            column(AddToWallet; AddToWallet)
            {
            }
            column(AddOnItemNo; AddOnItemNo)
            {
            }
            dataitem(NpIa_POSEntryLineBundleId; "NPR NpIa POSEntryLineBundleId")
            {
                DataItemLink = POSEntrySaleLineId = NpIa_POSEntrySaleLineAddOn.AppliesToSaleLineId;
                SqlJoinType = LeftOuterJoin;
                column(BundleSequence; Bundle)
                {
                }
                column(ReferenceNumber; ReferenceNumber)
                {
                }
            }
        }

    }
}