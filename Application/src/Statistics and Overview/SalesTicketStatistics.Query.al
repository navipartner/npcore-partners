query 6014401 "NPR Sales Ticket Statistics"
{
    //   Object created for report 6014409 "NPR Sales Ticket Statistics"

    Caption = 'Sales Ticket Statistics';

    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            filter(Entry_Date_Filter; "Entry Date")
            {
            }
            filter(POS_Unit_No_Filter; "POS Unit No.")
            {
            }
            filter(Entry_Type_Filter; "Entry Type")
            {
            }
            filter(Salesperson_Code_Filter; "Salesperson Code")
            {
            }
            filter(Shortcut_Dim_1_Code_Filter; "Shortcut Dimension 1 Code")
            {
            }
            filter(Shortcut_Dim_2_Code_Filter; "Shortcut Dimension 2 Code")
            {
            }
            filter(Ending_Time_Filter; "Ending Time")
            {
            }
            column(Document_No; "Document No.")
            {
            }
            column(Amount_Incl_Tax; "Amount Incl. Tax")
            {
                Method = Sum;
            }

        }
    }
}