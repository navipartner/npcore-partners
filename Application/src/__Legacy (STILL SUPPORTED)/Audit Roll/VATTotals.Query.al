query 6014410 "NPR VAT Totals"
{
    // NPR5.51/ZESO/20190702  Object created

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

