query 6014423 "NPR Value Entry With Item Cat"
{
    Access = Internal;
    Caption = 'Value Entry With Item Category';

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            filter(Filter_Entry_Type; "Item Ledger Entry Type")
            {
            }
            filter(Filter_Entry_No; "Entry No.")
            {
            }
            filter(Filter_Source_No; "Source No.")
            {
            }
            column(Filter_Sales_Person; "Salespers./Purch. Code")
            {
            }
            filter(Filter_DateTime; "Posting Date")
            {
            }
            filter(Filter_Item_No; "Item No.")
            {
            }
            filter(Filter_Dim_1_Code; "Global Dimension 1 Code")
            {
            }
            filter(Filter_Dim_2_Code; "Global Dimension 2 Code")
            {
            }
            filter(Filter_Location_Code; "Location Code")
            {
            }
            column(Item_No; "Item No.")
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
            column(Sum_Discount_Amount; "Discount Amount")
            {
                Method = Sum;
            }
            column(Sum_Valued_Quantity; "Valued Quantity")
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
                filter(Filter_Item_Category_Code; "Item Category Code")
                {
                }
                column(Item_Category_Code; "Item Category Code")
                {
                }
                dataitem(Item; Item)
                {
                    DataItemLink = "No." = Item_Ledger_Entry."Item No.";
                    SqlJoinType = InnerJoin;
                    filter(Filter_Group_sale; "NPR Group sale")
                    {
                    }
                }
            }
        }
    }
}