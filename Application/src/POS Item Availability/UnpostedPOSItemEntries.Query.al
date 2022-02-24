query 6014407 "NPR Unposted POS Item Entries"
{
    Access = Internal;
    QueryType = Normal;

    elements
    {
        dataitem(PosEntry; "NPR POS Entry")
        {
            DataItemTableFilter = "Post Item Entry Status" = filter(Unposted | "Error while Posting");

            dataitem(PosEntrySalesLine; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = PosEntry."Entry No.";
                DataItemTableFilter = Type = const(Item);
                SqlJoinType = InnerJoin;

                column(Location_Code; "Location Code") { }
                column(Item_No; "No.") { }
                column(Variant_Code; "Variant Code") { }
                column(Serial_No; "Serial No.") { }
                column(Sum_Quantity_Base; "Quantity (Base)")
                {
                    Method = Sum;
                }
            }
        }
    }
}