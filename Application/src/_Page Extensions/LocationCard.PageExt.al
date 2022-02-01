pageextension 6014460 "NPR Location Card" extends "Location Card"
{
    layout
    {
        addafter("Use As In-Transit")
        {
            field("NPR Store Group Code"; Rec."NPR Store Group Code")
            {

                ToolTip = 'Specifies a Group Code that a set of POS Stores can be grouped into for BI purposes.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}