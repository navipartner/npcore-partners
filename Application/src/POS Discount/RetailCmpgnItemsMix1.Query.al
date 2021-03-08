query 6014614 "NPR Retail Cmpgn. Items Mix 1"
{
    elements
    {
        dataitem(Retail_Campaign_Line; "NPR Retail Campaign Line")
        {
            DataItemTableFilter = Type = CONST("Mixed Discount"), Code = FILTER(<> '');
            filter(Campaign_Code; "Campaign Code")
            {
            }
            filter(Discount_Code; "Code")
            {
            }
            dataitem(Mixed_Discount_Line; "NPR Mixed Discount Line")
            {
                DataItemLink = Code = Retail_Campaign_Line.Code;
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Disc. Grouping Type" = CONST("Item Group"), "No." = FILTER(<> '');
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
}

