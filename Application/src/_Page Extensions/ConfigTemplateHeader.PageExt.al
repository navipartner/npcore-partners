pageextension 6014402 "NPR Config. Template Header" extends "Config. Template Header"
{
    layout
    {
        addlast(General)
        {
            field("NPR Instance No. Series"; Rec."Instance No. Series")
            {

                ToolTip = 'Specifies the value of the Instance No. Series field';
                ApplicationArea = NPRRetail;
            }
        }
    }
}