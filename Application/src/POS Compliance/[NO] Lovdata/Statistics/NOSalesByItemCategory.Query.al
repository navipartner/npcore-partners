query 6014468 "NPR NO Sales By Item Category"
{
    Access = Internal;
    Caption = 'NO Sales By Item Category';
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

            dataitem(POSEntrySalesLine; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = POSEntry."Entry No.";

                column(ItemCategoryCode; "Item Category Code") { }
                column(Quantity; Quantity) { Method = Sum; }
                column(AmountInclVATLCY; "Amount Incl. VAT (LCY)") { Method = Sum; }
            }
        }
    }
}