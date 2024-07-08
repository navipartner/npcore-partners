query 6014415 "NPR POS Salesperson Stats"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'POS Salesperson Stats';
    OrderBy = Descending(Sales_Amount_Actual);
    TopNumberOfRows = 20;

    elements
    {
        dataitem(Salesperson_Purchaser; "Salesperson/Purchaser")
        {
            column(Name; Name)
            {
            }

            dataitem(NPR_Aux__Value_Entry; "Value Entry")
            {
                DataItemLink = "Salespers./Purch. Code" = Salesperson_Purchaser.Code;
                SqlJoinType = InnerJoin;
                DataItemTableFilter = "Item Ledger Entry Type" = const(Sale);

                filter(Posting_Date; "Posting Date")
                {
                }

                column(Discount_Amount; "Discount Amount")
                {
                    Method = Sum;
                }

                column(Sales_Amount_Actual; "Sales Amount (Actual)")
                {
                    Method = Sum;
                }

                column(Cost_Amount_Actual; "Cost Amount (Actual)")
                {
                    Method = Sum;
                }
            }
        }
    }
}