query 6014617 "NPR Mixed Disc. Items Mix 0"
{
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Mixed Discount Line (Item)


    elements
    {
        dataitem(Mixed_Discount_Line; "NPR Mixed Discount Line")
        {
            DataItemTableFilter = "Disc. Grouping Type" = CONST(Item), "No." = FILTER(<> '');
            filter(Discount_code; "Code")
            {
            }
            filter(No; "No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = Mixed_Discount_Line."No.";
                SqlJoinType = InnerJoin;
                column(Item_No; "No.")
                {
                }
            }
        }
    }
}

