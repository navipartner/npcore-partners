query 6014413 "NPR Sales Stat. -Item Cat Qty"
{
    Caption = 'Sales Statistics -Item Cat Qty';

    elements
    {
        dataitem(Item_Ledger_Entry; "NPR Aux. Item Ledger Entry")
        {
            filter(Filter_Entry_Type; "Entry Type")
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
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}

