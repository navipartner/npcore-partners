query 6014432 "NPR Sales Statistics by Depar"
{
    Caption = 'Sales and Cost Summary by Dimension';
    QueryType = Normal;

    elements
    {
        dataitem(valueEntry; "Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type" = const(Sale);
            filter(Posting_Date_Filter; "Posting Date") { }
            filter(Global_Dimension_1_Filter; "Global Dimension 1 Code") { }
            filter(Global_Dimension_2_Filter; "Global Dimension 2 Code") { }
            filter(Salespers__Purch__Filter; "Salespers./Purch. Code") { }
            column(Dimension_1_Code; "Global Dimension 1 Code") { }
            column(Sales_Amount__Actual; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(Cost_Amount__Actual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(Item_Ledger_Entry_Quantity; "Item Ledger Entry Quantity")
            {
                Method = Sum;
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = valueEntry."Item No.";
                SqlJoinType = InnerJoin;
                filter(Vendor_No_Filter; "Vendor No.") { }
            }
        }
    }
}
