query 6014409 "NPR SPerson Turn. Item Cat."
{
    Access = Internal;
    Caption = 'SPerson Turn. Item Cat.';
    QueryType = Normal;

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type" = const(Sale);

            filter(Filter_Entry_No; "Entry No.") { }
            filter(Filter_Source_No; "Source No.") { }
            filter(Filter_DateTime; "Posting Date") { }
            filter(Filter_Item_No; "Item No.") { }
            filter(Filter_Dim_1_Code; "Global Dimension 1 Code") { }
            filter(Filter_Dim_2_Code; "Global Dimension 2 Code") { }
            filter(Filter_Location_Code; "Location Code") { }
            column(Salespers_Purch_Code; "Salespers./Purch. Code") { }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sum_Invoiced_Quantity; "Invoiced Quantity")
            {
                Method = Sum;
            }
            dataitem(Item_Ledger_Entry; "Item Ledger Entry")
            {
                DataItemLink = "Entry No." = Value_Entry."Item Ledger Entry No.";
                SqlJoinType = InnerJoin;

                column(Item_Category_Code; "Item Category Code") { }
            }
        }
    }
}