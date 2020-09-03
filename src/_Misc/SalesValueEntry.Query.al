query 6151481 "NPR Sales Value Entry"
{
    // MAG1.17/BHR/20150528  CASE 212983 Navishop rolecenter layout(chart)
    // MAG1.17/BHR/20150619  CASE 216856 Changed query base on "value entry" instead of "Cust ledger enntry"
    // MAG1.20/BHR/20150819 CASE 220881 Changed filter on Value Entry
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

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

