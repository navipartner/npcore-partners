query 6059804 "NPR Retail Sales by Dim. 1"
{
    // NPR5.29/BHR/20160104 CASE 262439 Query for sales by dimension1 on value entry (used on chart)

    Caption = 'Retail Sales by Dimension 1';

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
            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
        }
    }
}

