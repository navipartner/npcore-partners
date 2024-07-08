query 6014417 "NPR POS Entry with Sales Lines"
{
    Access = Internal;
    Caption = 'POS Entry with Sales Lines';

    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            column(Posting_Date; "Posting Date")
            {
            }
            column(POS_Unit_No; "POS Unit No.")
            {
            }
            dataitem(POS_Sales_Line; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = POS_Entry."Entry No.";
                SqlJoinType = InnerJoin;
                column(POS_Entry_No; "POS Entry No.")
                {
                }
                column(Line_No; "Line No.")
                {
                }
                column(Type; Type)
                {
                }
                column(No; "No.")
                {
                }
                column(Location_Code; "Location Code")
                {
                }
                column(Dimension_Set_ID; "Dimension Set ID")
                {
                }
                column(Exclude_from_Posting; "Exclude from Posting")
                {
                }
                dataitem(Value_Entry; "Value Entry")
                {
                    DataItemLink = "Item Ledger Entry No." = POS_Sales_Line."Item Entry No.";
                    DataItemTableFilter = "Item Ledger Entry Type" = FILTER(Sale);
                    column(Sum_Cost_Amount_Actual; "Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}

