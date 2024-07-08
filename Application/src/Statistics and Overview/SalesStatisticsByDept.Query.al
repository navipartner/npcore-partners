query 6014421 "NPR Sales Statistics By Dept"
{
    Access = Internal;
    Caption = 'Sales Statistics By Dept';

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(Entry_Type; "Entry Type")
            {

            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Global_Dimension_1_Code; "Global Dimension 1 Code")
            {

            }
            column(Global_Dimension_2_Code; "Global Dimension 2 Code")
            {

            }
            column(Item_Category_Code; "Item Category Code")
            {

            }
            column(Source_Type; "Source Type")
            {

            }
            column(Source_No_; "Source No.")
            {

            }
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
            filter(Filter_Source_Type; "Source Type")
            {
            }
            filter(Filter_Source_No; "Source No.")
            {
            }
            filter(Filter_Item_Category_Code; "Item Category Code")
            {
            }

            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = Item_Ledger_Entry."Item No.";
                SqlJoinType = InnerJoin;
                filter(Filter_Vendor_No; "Vendor No.")
                {
                }
                column(Vendor_No; "Vendor No.")
                {
                }
            }
        }
    }
}