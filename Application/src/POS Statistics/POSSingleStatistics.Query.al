query 6014414 "NPR POS Single Statistics"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'POS Single Statistics';
    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            filter(Entry_No_; "Entry No.")
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