pageextension 6014467 "NPR Shipping Agent Services" extends "Shipping Agent Services"
{
    layout
    {
        addafter(Description)
        {
            field("NPR Service Demand"; Rec."NPR Service Demand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Service Demand field';
            }
            field("NPR Notification Service"; Rec."NPR Notification Service")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Notification Service field';
            }
            field("NPR Default Option"; Rec."NPR Default Option")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Default Option field';
            }
        }

    }
}