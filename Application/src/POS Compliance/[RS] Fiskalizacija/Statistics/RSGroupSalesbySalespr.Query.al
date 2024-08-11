query 6014478 "NPR RS Group Sales by Salespr."
{
    Access = Internal;
    Caption = 'RS Group Sales by Salesperson';
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
            filter(EntryDate; "Entry Date") { }
            column(SalespersonCode; "Salesperson Code") { }
            column(Count) { Method = Count; }
        }
    }
}