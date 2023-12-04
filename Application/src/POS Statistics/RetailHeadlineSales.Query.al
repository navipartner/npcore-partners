query 6014429 "NPR Retail Headline Sales"
{
    Access = Internal;
    Caption = 'Retail Headline Sales';
    QueryType = Normal;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            filter(PostingDate; "Posting Date") { }
            filter(DocumentType; "Document Type") { }

            column(SalesAmountActual; "Sales Amount (Actual)") { Method = Sum; }
        }
    }
}