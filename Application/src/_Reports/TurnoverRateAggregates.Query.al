query 6014438 "NPR Turnover Rate Aggregates"
{
    Access = Internal;
    Caption = 'Turnover Rate Aggregates';
    QueryType = Normal;
    DataAccessIntent = ReadOnly;

    // Purpose-built for report 6014427 "NPR Turnover Rate" (its only consumer): do not add columns - the SQL grouping would change.

    elements
    {
        dataitem(Value_Entry; "Value Entry")
        {
            column(Item_No; "Item No.")
            {
            }
            column(Item_Ledger_Entry_Type; "Item Ledger Entry Type")
            {
            }
            column(Sales_Amount_Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Cost_Amount_Actual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Purchase_Amount_Actual; "Purchase Amount (Actual)")
            {
                Method = Sum;
            }
            column(Invoiced_Quantity; "Invoiced Quantity")
            {
                Method = Sum;
            }
            filter(Item_Ledger_Entry_Type_Filter; "Item Ledger Entry Type")
            {
            }
            filter(Posting_Date_Filter; "Posting Date")
            {
            }
            filter(Global_Dimension_1_Filter; "Global Dimension 1 Code")
            {
            }
            filter(Global_Dimension_2_Filter; "Global Dimension 2 Code")
            {
            }
            filter(Location_Filter; "Location Code")
            {
            }
            filter(Variant_Filter; "Variant Code")
            {
            }
            filter(Drop_Shipment_Filter; "Drop Shipment")
            {
            }
        }
    }
}
