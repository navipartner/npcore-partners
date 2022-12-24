query 6014422 "NPR Sales Statistics By Person"
{
    Access = Internal;
    Caption = 'Sales Statistics By Dept';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            filter(Filter_Entry_Type; "Entry Type")
            {
            }
            filter(Filter_Posting_Date; "Posting Date")
            {
            }
            filter(Filter_Global_Dimension_1_Code; "Global Dimension 1 Code")
            {
            }
            filter(Filter_Global_Dimension_2_Code; "Global Dimension 2 Code")
            {
            }
            filter(Filter_Item_Category_Code; "Item Category Code")
            {
            }
            filter(Filter_Source_Type; "Source Type")
            {
            }
            filter(Filter_Source_No; "Source No.")
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            dataitem(Value_Entry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = Item_Ledger_Entry."Entry No.";
                SqlJoinType = InnerJoin;
                filter(Filter_SalesPers_Purch_Code; "Salespers./Purch. Code")
                {
                }
                dataitem(Item; Item)
                {
                    DataItemLink = "No." = Value_Entry."Item No.";
                    SqlJoinType = InnerJoin;
                    filter(Filter_Item_No_; "No.")
                    {
                    }
                    filter(Filter_Vendor_No_; "Vendor No.")
                    {
                    }
                }
            }
        }
    }
}