pageextension 6014464 "NPR General Journal" extends "General Journal"
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