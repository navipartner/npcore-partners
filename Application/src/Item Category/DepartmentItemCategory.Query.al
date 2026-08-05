query 6014426 "NPR Department/Item Category"
{
    Access = Internal;
    Caption = 'Department/Item Category';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    // Purpose-built for report 6014420 "NPR Item Category Top" (its only consumer): do not add columns - the SQL grouping would change.

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Sale);

            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            column(Item_Category_Code; "Item Category Code")
            {
            }
            filter(Filter_Posting_Date; "Posting Date")
            {
            }
            dataitem(Value_Entry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = Item_Ledger_Entry."Entry No.";
                SqlJoinType = InnerJoin;

                column(Quantity; "Item Ledger Entry Quantity")
                {
                    Method = Sum;
                }
                column(Sales_Amount_Actual; "Sales Amount (Actual)")
                {
                    ColumnFilter = Sales_Amount_Actual = filter(> 0);
                    Method = Sum;
                }
                column(Cost_Amount_Actual; "Cost Amount (Actual)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
