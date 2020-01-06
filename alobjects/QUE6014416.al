query 6014416 "Sales Stats - Item Cat Sales"
{
    // NPR5.52/ZESO/20191010  Object created

    Caption = 'Sales Stats - Item Cat Sales';

    elements
    {
        dataitem(Value_Entry;"Value Entry")
        {
            filter(Filter_Entry_Type;"Item Ledger Entry Type")
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
            column(Item_Category_Code;"Item Category Code")
            {
            }
            column(Sum_Sales_Amount_Actual;"Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

