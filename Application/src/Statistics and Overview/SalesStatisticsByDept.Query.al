query 6014421 "NPR Sales Statistics By Dept"
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
        }
    }
}