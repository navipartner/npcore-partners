pageextension 6014481 "NPR Resource Card" extends "Resource Card"
{
    layout
    {
        addafter("Time Sheet Approver User ID")
        {
            field("NPR Over Capacitate Resource"; Rec."NPR Over Capacitate Resource")
            {

                ToolTip = 'Specifies if the task allocation can be exceeded, or not reach the maximum capacity.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Employment Date")
        {
            field("NPR E-Mail"; Rec."NPR E-Mail")
            {

                ToolTip = 'Specifies the E-mail address of the resource.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}