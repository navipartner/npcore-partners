query 6014618 "NPR Mixed Disc. Items Mix 1"
{
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Mixed Discount Line (Item Group)


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
                DataItemLink = "NPR Item Group" = Mixed_Discount_Line."No.";
                SqlJoinType = InnerJoin;
                column(Item_No; "No.")
                {
                }
            }
        }
    }
}

