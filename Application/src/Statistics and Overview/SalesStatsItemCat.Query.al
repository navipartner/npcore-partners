﻿query 6014416 "NPR Sales Stats: Item Cat."
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
            // filter(Filter_Item_Category_Code; "NPR Item Category Code")
            // {
            // }
            filter(Filter_Dim_1_Code; "Global Dimension 1 Code")
            {
            }
            filter(Filter_Dim_2_Code; "Global Dimension 2 Code")
            {
            }
            // filter(Filter_Vendor_No; "NPR Vendor No.")
            // {
            // }
            filter(Filter_Location_Code; "Location Code")
            {
            }
            // column(Item_Category_Code; "NPR Item Category Code")
            // {
            // }
            column(Item_No; "Item No.")
            {
            }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

