query 6014434 "NPR Prepmt. Inv. Amt. Query"
{
    Access = Internal;
    Caption = 'Prepayment Invoice Amount Query';

    elements
    {
        dataitem(SalesInvHeader; "Sales Invoice Header")
        {
            DataItemTableFilter = "Prepayment Invoice" = const(true);

            column(PrepmtOrderNo; "Prepayment Order No.") { }

            dataitem(SalesInvLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = SalesInvHeader."No.";
                SqlJoinType = InnerJoin;

                column(AmtInclVAT; "Amount Including VAT") { Method = Sum; }
            }
        }
    }
}
