pageextension 6014427 "NPR Responsibility Center Card" extends "Responsibility Center Card"
{
    layout
    {
        addafter("Location Code")
        {

            field("NPR Picture"; Rec."NPR Image")
            {
                ToolTip = 'Display the picture of the Responsibility Center.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}