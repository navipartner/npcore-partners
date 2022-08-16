query 6014419 "NPR POS Entry Sales Line"
{
    Access = Internal;
    QueryType = Normal;

    elements
    {
        dataitem(NPR_POS_Entry_Sales_Line; "NPR POS Entry Sales Line")
        {
            column(POS_Entry_No_; "POS Entry No.") { }
            column(Entry_Date; "Entry Date") { }
            column(Document_No_; "Document No.") { }
            column(Starting_Time; "Starting Time") { }
            column(Ending_Time; "Ending Time") { }
            column(POS_Store_Code; "POS Store Code") { }
            column(POS_Unit_No_; "POS Unit No.") { }
            column(Salesperson_Code; "Salesperson Code") { }
            column(Type; Type) { }
            column(No_; "No.") { }
            column(Description; Description) { }
            column(Description_2; "Description 2") { }
            column(Customer_No_; "Customer No.") { }
            column(Quantity; Quantity) { }
            column(Unit_of_Measure_Code; "Unit of Measure Code") { }
            column(Unit_Price; "Unit Price") { }
            column(Line_Discount__; "Line Discount %") { }
            column(Amount_Incl__VAT; "Amount Incl. VAT") { }
        }
    }
}