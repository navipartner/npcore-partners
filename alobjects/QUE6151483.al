query 6151483 "Top 10 Salespersons"
{
    // MAG1.20/BHR/20150528  CASE 223709 Build query to select top 10 salespersons.
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.47/BHR /20191023 CASE 327702 Remove ReverseSign for Sales (Qty.)
    // MAG2.17/BHR/20181023  CASE 333486 Add sorting On sales Quantity
    // MAG2.17/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'Top 10 Salespersons';
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

