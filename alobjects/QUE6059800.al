query 6059800 "Retail Top 10 Items by Qty."
{
    // NC1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout
    // NC1.22/BHR/20160107 CASE 227440 changed the Orderby property to Ascending
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03
    // NPR5.48/JDH /20181109 CASE 334163 Missing Object Caption Added

    Caption = 'Retail Top 10 Items by Qty.';
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

