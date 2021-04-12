query 6014400 "NPR POS Turnover"
{
    QueryType = Normal;

    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            column(POS_Store_Code; "POS Store Code")
            {

            }
            column(POS_Unit_No; "POS Unit No.")
            {

            }
            filter(Posting_Date; "Posting Date")
            {

            }
            dataitem(POS_Sales_Line; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = POS_Entry."Entry No.";
                SqlJoinType = InnerJoin;

                dataitem(Value_Entry; "Value Entry")
                {
                    DataItemLink = "Item Ledger Entry No." = POS_Sales_Line."Item Entry No.";
                    SqlJoinType = InnerJoin;

                    column(Cost_Amount_Actual; "Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }

                    column(Sales_Amount_Actual; "Sales Amount (Actual)")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}