query 6151480 "NPR Top 10 Items by Quantity"
{
    Access = Internal;
    Caption = 'Top 10 Items by Quantity';
    OrderBy = Ascending(Sum_Invoiced_Quantity);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            filter(Posting_Date; "Posting Date")
            {
            }
            filter(Item_Ledger_Entry_Type; "Item Ledger Entry Type")
            {
                ColumnFilter = Item_Ledger_Entry_Type = CONST(Sale);
            }
            column(Item_No; "Item No.")
            {
            }
            column(Sum_Invoiced_Quantity; "Invoiced Quantity")
            {
                Method = Sum;
            }
        }
    }
}

