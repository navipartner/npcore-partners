pageextension 6014468 "NPR Blanket Sales Order" extends "Blanket Sales Order"
{
    layout
    {
        addafter(Status)
        {
            field("NPR Group Code"; Rec."NPR Group Code")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Group Code field.';
            }
        }
    }
}