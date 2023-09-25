query 6014466 "NPR Salesperson VE Sales Qty"
{
    Access = Internal;
    Caption = 'Salesperson Stats - Value Entry Sales';

    elements
    {
        dataitem(Item; Item)
        {
            filter(Filter_Item_No; "No.") { }
            filter(Filter_Group_sale; "NPR Group sale") { }
            filter(Filter_Item_Category_Code; "Item Category Code") { }

            column(Item_No_; "No.") { }

            dataitem(Value_Entry; "Value Entry")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Item No." = Item."No.";
                DataItemTableFilter = "Item Ledger Entry Type" = const(Sale);

                filter(Filter_PostingDate; "Posting Date") { }
                filter(Filter_Dim_1_Code; "Global Dimension 1 Code") { }
                filter(Filter_Salesperson; "Salespers./Purch. Code") { }

                column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
                {
                    Method = Sum;
                }
                column(Sum_Invoiced_Quantity; "Invoiced Quantity")
                {
                    Method = Sum;
                }
            }
        }
    }
}