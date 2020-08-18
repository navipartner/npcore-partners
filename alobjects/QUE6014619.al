query 6014619 "Mixed Discount Items (Mix 2)"
{
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Mixed Discount Line (Item Disc. Group)


    elements
    {
        dataitem(Mixed_Discount_Line;"Mixed Discount Line")
        {
            DataItemTableFilter = "Disc. Grouping Type"=CONST("Item Disc. Group"),"No."=FILTER(<>'');
            filter(Discount_Code;"Code")
            {
            }
            filter(No;"No.")
            {
            }
            dataitem(Item;Item)
            {
                DataItemLink = "Item Disc. Group"=Mixed_Discount_Line."No.";
                SqlJoinType = InnerJoin;
                column(Item_No;"No.")
                {
                }
            }
        }
    }
}

