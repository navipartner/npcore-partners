pageextension 6014467 "NPR Shipping Agent Services" extends "Shipping Agent Services"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Service Demand"; Rec."NPR Service Demand")
            {

                ToolTip = 'Enable defining the type of service (either e-mail or SMS).';
                ApplicationArea = NPRRetail;
            }
            field("NPR Notification Service"; Rec."NPR Notification Service")
            {

                ToolTip = 'Enable activating the notification service.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Default Option"; Rec."NPR Default Option")
            {

                ToolTip = 'Enable specifying if the option will be used as default.';
                ApplicationArea = NPRRetail;
            }
        }

    }
}