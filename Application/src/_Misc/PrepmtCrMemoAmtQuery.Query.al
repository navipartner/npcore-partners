query 6014435 "NPR Prepmt. CrM. Amt. Query"
{
    Access = Internal;
    Caption = 'Prepayment Credit Memo Amount Query';

    elements
    {
        dataitem(SalesCrMemoHeader; "Sales Cr.Memo Header")
        {
            DataItemTableFilter = "Prepayment Credit Memo" = const(true);

            column(PrepmtOrderNo; "Prepayment Order No.") { }

            dataitem(SalesCrMemoLine; "Sales Cr.Memo Line")
            {
                DataItemLink = "Document No." = SalesCrMemoHeader."No.";
                SqlJoinType = InnerJoin;

                column(AmtInclVAT; "Amount Including VAT") { Method = Sum; }
            }
        }
    }
}
