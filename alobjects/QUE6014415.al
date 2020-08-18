query 6014415 "Sales Stats - Item Grp Sales"
{
    // NPR5.52/ZESO/20191010  Object created
    // NPR5.53/JAKUBV/20200121  CASE 371446-01 Transport NPR5.53 - 21 January 2020
    // NPR5.55/ZESO/20200708  CASE 378805 Added Location Code filter

    Caption = 'Sales Stats - Item Grp Sales';

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
            filter(Filter_Vendor_No;"Vendor No.")
            {
            }
            filter(Filter_Location_Code;"Location Code")
            {
            }
            column(Item_Group_No;"Item Group No.")
            {
            }
            column(Sum_Sales_Amount_Actual;"Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

