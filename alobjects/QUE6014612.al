query 6014612 "Retail Campaign Items (Period)"
{
    // MAG2.26/MHA /20200507  CASE 401235 Object created - returns Items used on Period Discount Line related to Retail Campaign


    elements
    {
        dataitem(Retail_Campaign_Line;"Retail Campaign Line")
        {
            DataItemTableFilter = Type=CONST("Period Discount"),Code=FILTER(<>'');
            filter(Campaign_Code;"Campaign Code")
            {
            }
            filter(Discount_Code;"Code")
            {
            }
            dataitem(Period_Discount_Line;"Period Discount Line")
            {
                DataItemLink = Code=Retail_Campaign_Line.Code;
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Item No."=FILTER(<>'');
                dataitem(Item;Item)
                {
                    DataItemLink = "No."=Period_Discount_Line."Item No.";
                    SqlJoinType = InnerJoin;
                    column(Item_No;"No.")
                    {
                    }
                }
            }
        }
    }
}

