pageextension 6014503 "NPR Payment Journal" extends "Payment Journal"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Prepayment"; Rec.Prepayment)
            {
                ApplicationArea = NPRRSLocal;
                ToolTip = 'Specifies the value of the Prepayment field.';
            }
        }
    }
}