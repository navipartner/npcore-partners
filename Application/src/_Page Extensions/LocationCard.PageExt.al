pageextension 6014460 "NPR Location Card" extends "Location Card"
{
    layout
    {
        addafter("Use As In-Transit")
        {
            field("NPR Store Group Code"; Rec."NPR Store Group Code")
            {

                ToolTip = 'Specifies the value of the NPR Store Group Code field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}