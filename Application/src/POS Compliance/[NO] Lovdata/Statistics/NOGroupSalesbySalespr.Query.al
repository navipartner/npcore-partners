query 6014428 "NPR NO Group Sales by Salespr."
{
    Access = Internal;
    Caption = 'NO Group Sales by Salesperson';
    QueryType = Normal;

    elements
    {
        dataitem(POSEntry; "NPR POS Entry")
        {
            DataItemTableFilter = "System Entry" = const(false);

            filter(EntryNo; "Entry No.") { }
            filter(EntryType; "Entry Type") { }
            filter(POSStoreCode; "POS Store Code") { }
            filter(POSUnitNo; "POS Unit No.") { }
            column(SalespersonCode; "Salesperson Code") { }
            column(Count) { Method = Count; }
        }
    }
}