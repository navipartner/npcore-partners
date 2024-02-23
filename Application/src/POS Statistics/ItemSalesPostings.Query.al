query 6014430 "NPR Item Sales Postings"
{
    Access = Internal;
    Caption = 'Item Sales Postings';
    QueryType = Normal;

    elements
    {
        dataitem(ValueEntry; "Value Entry")
        {
            DataItemTableFilter = "Item Ledger Entry Type" = const(Sale);

            column(ItemNo; "Item No.") { }
            filter(GlobalDimension1Code; "Global Dimension 1 Code") { }
            filter(GlobalDimension2Code; "Global Dimension 2 Code") { }
            filter(LocationCode; "Location Code") { }
            filter(PostingDate; "Posting Date") { }
            column(SalesQty; "Invoiced Quantity")
            {
                ColumnFilter = SalesQty = filter(<> 0);
                Method = Sum;
                ReverseSign = true;
            }
            column(SalesLCY; "Sales Amount (Actual)")
            {
                Method = Sum;
            }
            column(DiscountAmount; "Discount Amount")
            {
                Method = Sum;
                ReverseSign = true;
            }
            column(CostAmountNonInvtbl; "Cost Amount (Non-Invtbl.)") { Method = Sum; }

            dataitem(Item; Item)
            {
                DataItemLink = "No." = ValueEntry."Item No.";
                SqlJoinType = InnerJoin;
                filter(Item_VendorNo; "Vendor No.") { }
                filter(Item_ItemCategoryCode; "Item Category Code") { }
            }
        }
    }
}