query 6151240 "NP Retail Trailing Purch Order"
{
    Caption = 'Trailing Purchase Order Qry';

    elements
    {
        dataitem(Purchase_Header; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = CONST(Order);
            filter(ShipmentDate; "Posting Date")
            {
            }
            filter(Status; Status)
            {
            }
            filter(DocumentDate; "Document Date")
            {
            }
            column(CurrencyCode; "Currency Code")
            {
            }
            dataitem(Purchase_Line; "Purchase Line")
            {
                DataItemLink = "Document Type" = Purchase_Header."Document Type", "Document No." = Purchase_Header."No.";
                SqlJoinType = InnerJoin;
                DataItemTableFilter = Amount = FILTER(<> 0);
                column(Amount; Amount)
                {
                    Method = Sum;
                }
            }
        }
    }
}

