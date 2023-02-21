query 6014426 "NPR Department/Item Category"
{
    Access = Internal;
    Caption = 'Department/Item Category';
    QueryType = Normal;

    // This Query is specifically made for report 6014420 "NPR Item Category Top" and new columns should not be added
    // because groupings will be changed in resulting SQL query

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
            column(Quantity; Quantity)
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
            filter(Filter_Posting_Date; "Posting Date")
            {
            }
        }
    }
}