query 6059803 "Retail Top 10 SalesPersons"
{
    // NC1.20/BHR /20150528  CASE 223709 Build query to select top 10 salespersons.
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.47/BHR /20191023 CASE 327702 Remove ReverseSign for Sales (Qty.)
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'Retail Top 10 SalesPersons';
    OrderBy = Descending(Sales_Qty);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Salesperson_Purchaser;"Salesperson/Purchaser")
        {
            filter(Date_Filter;"Date Filter")
            {
            }
            column("Code";"Code")
            {
            }
            column(Name;Name)
            {
            }
            column(Sales_LCY;"Sales (LCY)")
            {
            }
            column(Sales_Qty;"Sales (Qty.)")
            {
            }
        }
    }
}

