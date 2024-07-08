query 6014413 "NPR Sales Stat. -Item Cat Qty"
{
    Access = Internal;
    Caption = 'Sales Statistics -Item Cat Qty';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            filter(Filter_Entry_Type; "Entry Type")
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
            filter(Filter_Vendor_No; "Source No.")
            {
            }
            filter(Filter_Location_Code; "Location Code")
            {
            }
            column(Item_Category_Code; "Item Category Code")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
            dataitem(POSEntrySalesLine; "NPR POS Entry Sales Line")
            {
                DataItemLink = "Item Entry No." = Item_Ledger_Entry."Entry No.";
                filter(Filter_Date; "Entry Date")
                {
                }
            }
        }
    }
}

