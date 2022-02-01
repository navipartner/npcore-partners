pageextension 6014420 "NPR Location List" extends "Location List"
{
    layout
    {
        addafter(Name)
        {
            field("NPR Store Group Code"; Rec."NPR Store Group Code")
            {

                Enabled = true;
                Visible = false;
                ToolTip = 'Specifies a Group Code that a set of POS Stores can be grouped into for BI purposes';
                ApplicationArea = NPRRetail;
            }
        }
    }
}