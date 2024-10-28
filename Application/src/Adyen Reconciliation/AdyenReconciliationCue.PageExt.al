pageextension 6014517 "NPR Adyen Reconciliation Cue" extends "Business Manager Role Center"
{
    Editable = false;

    layout
    {
        addbefore(Control16)
        {
            part("NPR Adyen Reconciliation Activities"; "NPR Adyen Rec. Activities")
            {
                Enabled = false;
                Visible = false;
                ApplicationArea = NPRRetail;
            }
        }
    }
}
