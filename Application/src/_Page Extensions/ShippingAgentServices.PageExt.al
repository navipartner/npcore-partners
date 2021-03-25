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
        addafter(CustomizedCalendar)
        {
            field("NPR Email Mandatory"; Rec."NPR Email Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Email Mandatory field';
            }
            field("NPR Phone Mandatory"; Rec."NPR Phone Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Phone Mandatory field';
            }
        }
    }
}