query 6014410 "NPR VAT Totals"
{
    Caption = 'VAT Totals';

    elements
    {
        dataitem(Audit_Roll; "NPR Audit Roll")
        {
            filter(Sales_Ticket_No; "Sales Ticket No.")
            {
            }
            column(VAT; "VAT %")
            {
            }
            column(Sum_Amount; Amount)
            {
                Method = Sum;
            }
            column(Sum_Amount_Including_VAT; "Amount Including VAT")
            {
                Method = Sum;
            }
        }
    }
}

