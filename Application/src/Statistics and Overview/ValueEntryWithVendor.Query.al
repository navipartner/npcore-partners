query 6014424 "NPR Value Entry With Vendor"
{
    Access = Internal;
    Caption = 'Sales Stats - Item Cat Sales';

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            filter(Filter_Entry_Type; "Item Ledger Entry Type")
            {
            }
            filter(Filter_DateTime; "Posting Date")
            {
            }
            filter(Filter_Item_No; "Item No.")
            {
            }
            filter(Filter_Source_No; "Source No.")
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
            filter(Filter_Salespers_Purch_Code; "Salespers./Purch. Code")
            {
            }
            filter(Filter_Cost_Amount_Actual; "Cost Amount (Actual)")
            {
            }
            column(Cost_per_Unit; "Cost per Unit")
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
                dataitem(Item; Item)
                {
                    DataItemLink = "No." = Value_Entry."Item No.";
                    SqlJoinType = InnerJoin;
                    filter(Filter_Vendor_No; "Vendor No.")
                    {
                    }
                }
            }
        }
    }
}