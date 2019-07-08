query 6151482 "Top 10 Cust. Sales"
{
    // MAG1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout
    // MAG1.17/BHR/20150528  CASE 216856 Build query on Value entry instead of Cust ledger entry
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

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

