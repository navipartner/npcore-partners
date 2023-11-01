query 6014469 "NPR RS KEP Book Dataset"
{
    Access = Internal;
    Caption = 'RS KEP Book';
    QueryType = Normal;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            column(Entry_No; "Entry No.") { }
            column(Location_Code; "Location Code") { }
            column(Document_Date; "Document Date") { }
            column(Posting_Date; "Posting Date") { }
            column(Source_No; "Source No.") { }
            column(Sales_Amount_Actual; "Sales Amount (Actual)") { }
            column(Cost_Amount_Actual; "Cost Amount (Actual)") { }
            column(Document_Type; "Document Type") { }
            column(Document_No; "Document No.") { }
        }
    }
}