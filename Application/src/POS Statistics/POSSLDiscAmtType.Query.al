query 6014402 "NPR POS SL Disc. Amt. Type"
{
    Access = Internal;
    Caption = 'POS Entry Sales Line Discount Amount Type';
    QueryType = Normal;

    elements
    {
        dataitem(POSEntrySaleLine; "NPR POS Entry Sales Line")
        {
            DataItemTableFilter = Type = const(Item);
            column(SalespersonCode; "Salesperson Code")
            {
            }
            column(DiscountType; "Discount Type")
            {
            }
            column(LineDscAmtExclVATLCY; "Line Dsc. Amt. Excl. VAT (LCY)")
            {
                Method = Sum;
            }
            filter(EntryDate; "Entry Date")
            {
            }
        }
    }
}