pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    layout
    {
        addafter("Description 2")
        {
            field("NPR Blocked"; Rec."NPR Blocked")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Blocked field';
            }
        }
    }
}