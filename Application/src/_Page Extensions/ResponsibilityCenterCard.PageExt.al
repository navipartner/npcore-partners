pageextension 6014427 "NPR Responsibility Center Card" extends "Responsibility Center Card"
{
    layout
    {
        addafter("Location Code")
        {

            field("NPR Picture"; Rec."NPR Picture")
            {
                ToolTip = 'Specifies the value of the Picture';
                ApplicationArea = Location;
            }
        }
    }
}