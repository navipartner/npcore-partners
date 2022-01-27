query 6151482 "NPR Top 10 Cust. Sales"
{
    Access = Internal;

    Caption = 'Top 10 Customer Sales';
    OrderBy = Descending(Sum_Sales_Amount_Actual);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            SqlJoinType = LeftOuterJoin;
            DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Sale), "Source Type" = FILTER(Customer), "Source No." = FILTER(<> '');
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

