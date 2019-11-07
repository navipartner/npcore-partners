query 6014411 "Sales Statistics - Item Qty"
{
    // NPR5.52/ZESO/20191010  Object created

    Caption = 'Sales Statistics - Item Qty';

    elements
    {
        dataitem(Item_Ledger_Entry;"Item Ledger Entry")
        {
            filter(Filter_Entry_Type;"Entry Type")
            {
            }
            filter(Filter_DateTime;"Document Date and Time")
            {
            }
            filter(Filter_Item_No;"Item No.")
            {
            }
            filter(Filter_Item_Group_No;"Item Group No.")
            {
            }
            filter(Filter_Item_Category_Code;"Item Category Code")
            {
            }
            filter(Filter_Dim_1_Code;"Global Dimension 1 Code")
            {
            }
            filter(Filter_Dim_2_Code;"Global Dimension 2 Code")
            {
            }
            column(Item_No;"Item No.")
            {
            }
            column(Sum_Quantity;Quantity)
            {
                Method = Sum;
            }
        }
    }
}

