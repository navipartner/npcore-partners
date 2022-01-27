query 6151223 "NPR NpCs Store Stock Status"
{
    QueryType = Normal;
    Caption = 'NpCs Store Stock Status';

    elements
    {
        dataitem(NpCs_Store_Stock_Item; "NPR NpCs Store Stock Item")
        {
            SqlJoinType = InnerJoin;
            DataItemTableFilter = "Stock Qty." = FILTER(>= 0);
            column(Item_No; "Item No.")
            {
            }
            column(Sum_Stock_Qty; "Stock Qty.")
            {
                Method = Sum;
            }
            filter(Store_Code; "Store Code")
            {
            }
            filter(Variant_Code; "Variant Code")
            {
            }
            column("Count")
            {
                Method = Count;
            }
        }
    }
}
