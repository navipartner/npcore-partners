query 6059802 "Retail Top 10 Cust. Sales"
{
    // NC1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout
    // NC1.17/BHR/20150528  CASE 216856 Build query on Value entry instead of Cust ledger entry
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03

    Caption = 'Top 10 Customer Sales';
    OrderBy = Descending(Sum_Sales_Amount_Actual);
    TopNumberOfRows = 10;

    elements
    {
        dataitem(Value_Entry;"Value Entry")
        {
            SqlJoinType = LeftOuterJoin;
            DataItemTableFilter = "Item Ledger Entry Type"=FILTER(Sale),"Source Type"=FILTER(Customer),"Source No."=FILTER(<>'');
            filter(Posting_Date;"Posting Date")
            {
            }
            column(Source_No;"Source No.")
            {
            }
            column(Sum_Sales_Amount_Actual;"Sales Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

