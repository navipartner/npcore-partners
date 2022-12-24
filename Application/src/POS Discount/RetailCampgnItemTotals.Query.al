query 6014610 "NPR Retail Campgn. Item Totals"
{
    Access = Internal;
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
                dataitem(NPR_POS_Entry_Sales_Line; "NPR POS Entry Sales Line")
                {
                    DataItemLink = "Discount Type" = Retail_Campaign_Line.Type, "Discount Code" = Retail_Campaign_Line.Code;
                    SqlJoinType = InnerJoin;
                    dataitem(Value_Entry; "Value Entry")
                    {
                        DataItemLink = "Item Ledger Entry No." = NPR_POS_Entry_Sales_Line."Item Entry No.";
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
}

