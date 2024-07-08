query 6151481 "NPR Sales Value Entry"
{
    Access = Internal;
    Caption = 'Sales Cust. Ledg. Entry';

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Sale);
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

