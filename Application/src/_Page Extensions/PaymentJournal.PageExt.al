pageextension 6014503 "NPR Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter(Correction)
        {
            field("NPR Prepayment"; Rec.Prepayment)
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Prepayment field.';
            }
        }
    }
}