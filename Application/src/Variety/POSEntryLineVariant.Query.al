query 6014502 "NPR POS Entry Line Variant"
{
    Access = Internal;
    Caption = 'POS Entry Line Variant Check';
    QueryType = Normal;

    elements
    {
        dataitem(NPR_POS_Entry; "NPR POS Entry")
        {
            DataItemTableFilter = "Post Item Entry Status" = filter(<> "Not To Be Posted");
            column(Entry_No_; "Entry No.") { }
            dataitem(NPR_POS_Entry_Sales_Line; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = NPR_POS_Entry."Entry No.";
                SqlJoinType = InnerJoin;
                column(Type; Type) { }
                column(No_; "No.") { }
                column(Variant_Code; "Variant Code") { }
                column(Item_Entry_No_; "Item Entry No.") { }
            }
        }
    }
}