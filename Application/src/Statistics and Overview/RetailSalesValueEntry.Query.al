query 6059801 "NPR Retail Sales Value Entry"
{
    Access = Internal;
    // NC1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout(chart)
    // NC1.17/BHR/20150619  CASE 216856 Changed query base on "value entry" instead of "Cust ledger enntry"
    // NC1.20/BHR/20150819 CASE 220881 Changed filter on Value Entry
    // NPR5.23.03/MHA/20160726  CASE 242557 Object renamed and re-versioned from NC1.22 to NPR5.23.03

    Caption = 'Sales Cust. Ledg. Entry';

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Sale);
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
        }
    }
}

