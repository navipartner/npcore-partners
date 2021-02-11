query 6014418 "NPR ClickNCollectSales_Stats"
{

    Caption = 'ClickNCollectSales_SalesStats';

    elements
    {
        dataitem(Audit_Roll; "NPR Audit Roll")
        {
            filter(Sale_Date_Filter; "Sale Date")
            {
            }
            filter(Register_No_Filter; "Register No.")
            {
            }
            filter(Sale_Type_Filter; "Sale Type")
            {
            }
            filter(Type_Filter; Type)
            {
            }
            filter(Salesperson_Code_Filter; "Salesperson Code")
            {
            }
            filter(Closing_Time_Filter; "Closing Time")
            {
            }
            filter(Shortcut_Dim_1_Code_Filter; "Shortcut Dimension 1 Code")
            {
            }
            filter(Shortcut_Dim_2_Code_Filter; "Shortcut Dimension 2 Code")
            {
            }
            filter(Sales_Ticket_No_Filter; "Sales Ticket No.")
            {
            }
            filter(Posted_Filter; Posted)
            {
            }
            column(Sales_Ticket_No; "Sales Ticket No.")
            {
            }
            column(Amount_Including_VAT; "Amount Including VAT")
            {
                Method = Sum;
            }
        }
    }
}

