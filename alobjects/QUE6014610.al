query 6014610 "Retail Campaign Item Totals"
{
    // NPR5.38.01/MHA /20171221  CASE 299436 Object created - Retail Campaign

    Caption = 'Retail Campaign Item Totals';

    elements
    {
        dataitem(Retail_Campaign_Header;"Retail Campaign Header")
        {
            filter("Code";"Code")
            {
            }
            dataitem(Retail_Campaign_Line;"Retail Campaign Line")
            {
                DataItemLink = "Campaign Code"=Retail_Campaign_Header.Code;
                SqlJoinType = InnerJoin;
                filter(Line_No;"Line No.")
                {
                }
                dataitem(Value_Entry;"Value Entry")
                {
                    DataItemLink = "Discount Type"=Retail_Campaign_Line.Type,"Discount Code"=Retail_Campaign_Line.Code;
                    SqlJoinType = InnerJoin;
                    column(Sum_Sales_Amount_Actual;"Sales Amount (Actual)")
                    {
                        Method = Sum;
                    }
                    column(Sum_Cost_Amount_Actual;"Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}

