query 6014610 "NPR Retail Campgn. Item Totals"
{
    Caption = 'Retail Campaign Item Totals';

    elements
    {
        dataitem(Retail_Campaign_Header; "NPR Retail Campaign Header")
        {
            filter("Code"; "Code")
            {
            }
            dataitem(Retail_Campaign_Line; "NPR Retail Campaign Line")
            {
                DataItemLink = "Campaign Code" = Retail_Campaign_Header.Code;
                SqlJoinType = InnerJoin;
                filter(Line_No; "Line No.")
                {
                }
                dataitem(Value_Entry; "NPR Aux. Value Entry")
                {
                    DataItemLink = "Discount Type" = Retail_Campaign_Line.Type, "Discount Code" = Retail_Campaign_Line.Code;
                    SqlJoinType = InnerJoin;
                    column(Sum_Sales_Amount_Actual; "Sales Amount (Actual)")
                    {
                        Method = Sum;
                    }
                    column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}

