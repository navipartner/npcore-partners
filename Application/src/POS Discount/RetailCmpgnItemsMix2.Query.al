query 6014615 "NPR Retail Cmpgn Items Mix 2"
{
    Access = Internal;
    Caption = 'Retail Cmpgn Items Mix 2';
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Mixed Discount Line (Item Disc. Group) related to Retail Campaign


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
                DataItemTableFilter = "Disc. Grouping Type" = CONST("Item Disc. Group"), "No." = FILTER(<> '');
                dataitem(Item; Item)
                {
                    DataItemLink = "Item Disc. Group" = Mixed_Discount_Line."No.";
                    SqlJoinType = InnerJoin;
                    column(Item_No; "No.")
                    {
                    }
                }
            }
        }
    }
}

