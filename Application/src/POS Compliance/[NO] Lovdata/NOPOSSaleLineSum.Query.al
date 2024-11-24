query 6014484 "NPR NO POS Sale Line Sum"
{
    Access = Internal;
    Caption = 'NO POS Sale Line Sum';
    QueryType = Normal;

    elements
    {
        dataitem(NPR_POS_Entry; "NPR POS Entry")
        {
            filter(POS_Entry_Type; "Entry Type") { }
            dataitem(NPR_POS_Entry_Sales_Line; "NPR POS Entry Sales Line")
            {
                DataItemLink = "POS Entry No." = NPR_POS_Entry."Entry No.";
                SqlJoinType = InnerJoin;
                filter(QuantityFilter; "Quantity") { }
                column(Total_Amt_Incl_Vat; "Amount Incl. VAT")
                {
                    Method = Sum;
                }
            }
        }
    }
}