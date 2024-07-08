query 6014401 "NPR Sales Ticket Statistics"
{
    //   Object created for report 6014409 "NPR Sales Ticket Statistics"
    Access = Internal;
    Caption = 'Sales Ticket Statistics';

    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            filter(Shortcut_Dim_1_Code_Filter; "Shortcut Dimension 1 Code")
            {
            }
            filter(Shortcut_Dim_2_Code_Filter; "Shortcut Dimension 2 Code")
            {
            }
            filter(Posting_Date_Filter; "Posting Date")
            {
            }
            column(Amount_Excl_Tax; "Amount Excl. Tax")
            {
                Method = Sum;
            }
            column(Return_Sales_Quantity; "Return Sales Quantity")
            {
                Method = Sum;
            }
            column(NumberOfEntries)
            {
                Method = Count;
            }
        }
    }
}