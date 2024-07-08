query 6014420 "NPR POS Entry Payment Line"
{
    Access = Internal;
    QueryType = Normal;

    elements
    {
        dataitem(NPR_POS_Entry_Payment_Line; "NPR POS Entry Payment Line")
        {
            column(POS_Entry_No_; "POS Entry No.") { }
            column(Entry_Date; "Entry Date") { }
            column(Document_No_; "Document No.") { }
            column(Starting_Time; "Starting Time") { }
            column(Ending_Time; "Ending Time") { }
            column(POS_Store_Code; "POS Store Code") { }
            column(POS_Unit_No_; "POS Unit No.") { }
            column(POS_Payment_Method_Code; "POS Payment Method Code") { }
            column(Description; Description) { }
            column(Amount; Amount) { }
            column(Amount__Sales_Currency_; "Amount (Sales Currency)") { }
            dataitem(NPR_POS_Entry; "NPR POS Entry")
            {
                DataItemLink = "Entry No." = NPR_POS_Entry_Payment_Line."POS Entry No.";
                column(Salesperson_Code; "Salesperson Code") { }
                column(Entry_Post_Status; "Post Entry Status") { }
            }
        }
    }
}