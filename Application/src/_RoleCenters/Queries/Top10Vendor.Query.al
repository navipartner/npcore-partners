query 6151241 "NPR Top 10 Vendor"
{
    Access = Internal;
    OrderBy = Descending(Sum_Sales_Amount_Actual);
    TopNumberOfRows = 10;
    Caption = 'Top 10 Vendor';

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            SqlJoinType = LeftOuterJoin;
            DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Purchase), "Source Type" = FILTER(Vendor), "Source No." = FILTER(<> '');
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Source_No; "Source No.")
            {
            }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

