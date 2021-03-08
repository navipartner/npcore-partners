query 6014618 "NPR Mixed Disc. Items Mix 1"
{
    elements
    {
        dataitem(Mixed_Discount_Line; "NPR Mixed Discount Line")
        {
            DataItemTableFilter = "Disc. Grouping Type" = CONST("Item Group"), "No." = FILTER(<> '');
            filter(Discount_Code; "Code")
            {
            }
            filter(No; "No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "Item Category Code" = Mixed_Discount_Line."No.";
                SqlJoinType = InnerJoin;
                column(Item_No; "No.")
                {
                }
            }
        }
    }
}

