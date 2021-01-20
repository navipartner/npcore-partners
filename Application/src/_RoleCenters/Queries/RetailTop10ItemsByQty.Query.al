query 6059800 "NPR Retail Top 10 ItemsByQty."
{
    Caption = 'Retail Top 10 Items by Qty.';
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

