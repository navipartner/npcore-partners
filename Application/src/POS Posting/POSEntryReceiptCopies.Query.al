query 6014474 "NPR POS Entry Receipt Copies"
{
    Access = Internal;
    Caption = 'POS Entry Receipt Copies';
    ReadState = ReadUncommitted;

    elements
    {
        dataitem(POSEntry; "NPR POS Entry")
        {
            DataItemTableFilter = "System Entry" = const(false);
            filter(POSEntryNo; "Entry No.") { }
            column(POSStoreCode; "POS Store Code") { }
            column(POSUnitNo; "POS Unit No.") { }
            column(AmountInclTax; "Amount Incl. Tax")
            {
                Method = Sum;
            }
            dataitem(POSAuditLog; "NPR POS Audit Log")
            {
                DataItemLink = "Acted on POS Entry No." = POSEntry."Entry No.";
                DataItemTableFilter = "Action Type" = const(RECEIPT_COPY);
                SqlJoinType = InnerJoin;
                column(NoOfReceiptCopies)
                {
                    Method = Count;
                }
            }
        }
    }
}