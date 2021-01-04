pageextension 6014467 "NPR Shipping Agent Services" extends "Shipping Agent Services"
{
    // PS1.00/LS/20141201  CASE 200150 Fields "Service Demand", "Notification Service", "Default Option"
    // NPR5.29/BHR/20161026 CASE 248684 Add fields "Sell to contact Mandatory","Email Mandatory","Phone Mandatory"
    layout
    {
        addafter(Description)
        {
            field("NPR Service Demand"; "NPR Service Demand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Service Demand field';
            }
            field("NPR Notification Service"; "NPR Notification Service")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Notification Service field';
            }
            field("NPR Default Option"; "NPR Default Option")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Default Option field';
            }
        }
        addafter(CustomizedCalendar)
        {
            field("NPR Email Mandatory"; "NPR Email Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Email Mandatory field';
            }
            field("NPR Phone Mandatory"; "NPR Phone Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Phone Mandatory field';
            }
        }
    }
}

