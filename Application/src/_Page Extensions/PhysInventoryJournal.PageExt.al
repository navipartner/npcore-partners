pageextension 6014407 "NPR Phys. Inventory Journal" extends "Phys. Inventory Journal"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Description 2"; Rec."NPR Description 2")
            {
                ToolTip = 'Specifies a second description of item variant, or item (if no variant is selected on the line).';
                ApplicationArea = NPRRetail;
            }
        }
    }
}