pageextension 6014470 "NPR Customer Ledger Entries" extends "Customer Ledger Entries"
{
    layout
    {
        addafter(Open)
        {
            field("NPR Prepayment"; Rec.Prepayment)
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Prepayment field.';
            }
        }
    }
}