query 6014444 "NPR RS Variant Sales Amounts"
{
    Access = Internal;
    Caption = 'RS Variant Sales Amounts';
    QueryType = Normal;

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Sale), "Document Type" = filter(<> "NPR Nivelation");
            filter(Filter_Item_No; "Item No.") { }
            filter(Filter_Variant_Code; "Variant Code") { }
            filter(Filter_Posting_Date; "Posting Date") { }
            filter(Filter_Location_Code; "Location Code") { }
            filter(Filter_Dim_1_Code; "Global Dimension 1 Code") { }
            filter(Filter_Dim_2_Code; "Global Dimension 2 Code") { }
            dataitem(Value_Entry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = Item_Ledger_Entry."Entry No.";
                SqlJoinType = InnerJoin;
                filter(Filter_Entry_Type; "Entry Type") { }
                filter(Filter_Invoiced_Quantity; "Invoiced Quantity") { }
                column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
                {
                    Method = Sum;
                }
                column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
                {
                    Method = Sum;
                }
                column(Sum_Cost_Amount_Non_Invtbl; "Cost Amount (Non-Invtbl.)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
