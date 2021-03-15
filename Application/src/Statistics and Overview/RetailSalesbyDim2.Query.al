query 6059805 "NPR Retail Sales by Dim. 2"
{
    Caption = 'Retail Sales by Dimension 2';

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
            column(Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
            }
        }
    }
}

