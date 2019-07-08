query 6151480 "Top 10 Items by Quantity"
{
    // MAG1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout
    // MAG1.22/BHR/20160107 CASE 227440 changed the Orderby property to Ascending
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'Top 10 Items by Quantity';
    OrderBy = Ascending(Sum_Invoiced_Quantity);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Value_Entry;"Value Entry")
        {
            filter(Posting_Date;"Posting Date")
            {
            }
            filter(Item_Ledger_Entry_Type;"Item Ledger Entry Type")
            {
                ColumnFilter = Item_Ledger_Entry_Type=CONST(Sale);
            }
            column(Item_No;"Item No.")
            {
            }
            column(Sum_Invoiced_Quantity;"Invoiced Quantity")
            {
                Method = Sum;
            }
        }
    }
}

