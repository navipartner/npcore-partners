pageextension 6014481 "NPR Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Time Sheet Approver User ID")
        {
            field("NPR Over Capacitate Resource"; Rec."NPR Over Capacitate Resource")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Over Capacitate Resource field';
            }
        }
        addafter("Employment Date")
        {
            field("NPR E-Mail"; Rec."NPR E-Mail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR E-Mail field';
            }
        }
    }
}

