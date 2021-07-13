pageextension 6014467 "NPR Shipping Agent Services" extends "Shipping Agent Services"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Service Demand"; Rec."NPR Service Demand")
            {

                ToolTip = 'Specifies the value of the NPR Service Demand field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Notification Service"; Rec."NPR Notification Service")
            {

                ToolTip = 'Specifies the value of the NPR Notification Service field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Default Option"; Rec."NPR Default Option")
            {

                ToolTip = 'Specifies the value of the NPR Default Option field';
                ApplicationArea = NPRRetail;
            }
        }

    }
}