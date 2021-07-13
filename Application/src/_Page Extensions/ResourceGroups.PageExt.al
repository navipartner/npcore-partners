pageextension 6014477 "NPR Resource Groups" extends "Resource Groups"
{
    layout
    {
        addafter(Name)
        {
            field("NPR E-Mail"; Rec."NPR E-Mail")
            {

                ToolTip = 'Specifies the value of the NPR E-Mail field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}