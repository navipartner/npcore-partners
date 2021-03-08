query 6014416 "NPR Sales Stats: Item Cat."
{
    Caption = 'Sales Stats - Item Cat Sales';

    elements
    {
        dataitem(Value_Entry; "NPR Aux. Value Entry")
        {
            filter(Filter_Entry_Type; "Item Ledger Entry Type")
            {
            }
            filter(Filter_DateTime; "Document Date and Time")
            {
            }
            filter(Filter_Item_No; "Item No.")
            {
            }
            filter(Filter_Item_Category_Code; "Item Category Code")
            {
            }
            filter(Filter_Dim_1_Code; "Global Dimension 1 Code")
            {
            }
            filter(Filter_Dim_2_Code; "Global Dimension 2 Code")
            {
            }
            filter(Filter_Vendor_No; "Vendor No.")
            {
            }
            filter(Filter_Location_Code; "Location Code")
            {
            }
            column(Item_Category_Code; "Item Category Code")
            {
            }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

