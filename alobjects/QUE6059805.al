query 6059805 "Retail Sales by Dimension 2"
{
    // NPR5.29/BHR/20160104 CASE 262439 Query for sales by dimension1 on value entry (used on chart)
    // NPR5.48/JDH /20181109 CASE 334163 Changed fieldname + caption

    Caption = 'Retail Sales by Dimension 2';

    elements
    {
        dataitem(Value_Entry;"Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type"=FILTER(Sale);
            filter(Posting_Date;"Posting Date")
            {
            }
            column(Sum_Sales_Amount_Actual;"Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sum_Cost_Amount_Actual;"Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Global_Dimension_2_Code;"Global Dimension 2 Code")
            {
            }
        }
    }
}

