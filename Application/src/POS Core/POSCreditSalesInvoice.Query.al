query 6014412 "NPR POS Credit Sales Invoice"
{
    Access = Internal;
    QueryType = Normal;
    Caption = 'POS Credit Sales Invoice';

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
            dataitem(Sales_Invoice_Header; "Sales Invoice Header")
            {
                DataItemLink = "Pre-Assigned No." = POS_Entry."Sales Document No.";
                SqlJoinType = InnerJoin;

                dataitem(Value_Entry; "Value Entry")
                {
                    DataItemLink = "Document No." = Sales_Invoice_Header."No.";
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
