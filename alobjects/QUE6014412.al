query 6014412 "Sales Statistics - Item Gr Qty"
{
    // NPR5.52/ZESO/20191010  Object created
    // NPR5.53/JAKUBV/20200121  CASE 371446-01 Transport NPR5.53 - 21 January 2020

    Caption = 'Sales Statistics - Item Group Qty';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
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
            filter(Filter_Item_Group_No; "Item Group No.")
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
            filter(Filter_Vendor_No;"Vendor No.")
            {
            }
            column(Item_Group_No; "Item Group No.")
            {
            }
            column(Sum_Quantity; Quantity)
            {
                Method = Sum;
            }
        }
    }
}

