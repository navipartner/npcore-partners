query 6014411 "NPR POS Credit Sales Cr. Memo"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'POS Credit Sales Cr. Memo';

    elements
    {
        dataitem(POS_Entry; "NPR POS Entry")
        {
            filter(POS_Store_Code; "POS Store Code")
            {

            }
            filter(POS_Unit_No; "POS Unit No.")
            {

            }
            filter(Posting_Date; "Posting Date")
            {

            }
            filter(Sales_Document_Type; "Sales Document Type")
            {

            }
            filter(Sales_Document_No_; "Sales Document No.")
            {

            }
            dataitem(Sales_Cr_Memo_Header; "Sales Cr.Memo Header")
            {
                DataItemLink = "Pre-Assigned No." = POS_Entry."Sales Document No.";
                SqlJoinType = InnerJoin;

                dataitem(Value_Entry; "Value Entry")
                {
                    DataItemLink = "Document No." = Sales_Cr_Memo_Header."No.";
                    SqlJoinType = InnerJoin;

                    column(Cost_Amount_Actual; "Cost Amount (Actual)")
                    {
                        Method = Sum;
                    }

                    column(Sales_Amount_Actual; "Sales Amount (Actual)")
                    {
                        Method = Sum;
                    }
                }
            }
        }
    }
}
