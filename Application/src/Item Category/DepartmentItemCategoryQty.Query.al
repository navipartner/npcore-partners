query 6014439 "NPR Department/Item Cat. Qty"
{
    Access = Internal;
    Caption = 'Department/Item Category Quantity';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    // Purpose-built for report 6014420 "NPR Item Category Top" (its only consumer): do not add columns - the SQL grouping would change.

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Sale);

            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            column(Item_Category_Code; "Item Category Code")
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            filter(Filter_Posting_Date; "Posting Date")
            {
            }
        }
    }
}
