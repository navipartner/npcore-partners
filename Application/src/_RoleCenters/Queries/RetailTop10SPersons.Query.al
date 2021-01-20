query 6059803 "NPR Retail Top 10 S.Persons"
{
    Caption = 'Retail Top 10 SalesPersons';
    OrderBy = Descending(Sales_Qty);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Salesperson_Purchaser; "Salesperson/Purchaser")
        {
            filter(Date_Filter; "Date Filter")
            {
            }
            column("Code"; "Code")
            {
            }
            column(Name; Name)
            {
            }
            column(Sales_LCY; "NPR Sales (LCY)")
            {
            }
            column(Sales_Qty; "NPR Sales (Qty.)")
            {
            }
        }
    }
}

