query 6014616 "NPR Period Discount Items"
{
    Caption = 'Period Discount Items';
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Period Discount Line


    elements
    {
        dataitem(Period_Discount_Line; "NPR Period Discount Line")
        {
            DataItemTableFilter = "Item No." = FILTER(<> '');
            filter(Discount_Code; "Code")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = Period_Discount_Line."Item No.";
                SqlJoinType = InnerJoin;
                column(Item_No; "No.")
                {
                }
            }
        }
    }
}

