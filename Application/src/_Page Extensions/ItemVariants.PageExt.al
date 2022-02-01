pageextension 6014458 "NPR Item Variants" extends "Item Variants"
{
    layout
    {
        addafter("Description 2")
        {
            field("NPR Blocked"; Rec."NPR Blocked")
            {

                ToolTip = 'Specifies if the Item Variant is blocked or not';
                ApplicationArea = NPRRetail;
            }
        }
    }
}