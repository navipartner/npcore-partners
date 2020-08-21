pageextension 6014467 pageextension6014467 extends "Shipping Agent Services"
{
    // PS1.00/LS/20141201  CASE 200150 Fields "Service Demand", "Notification Service", "Default Option"
    // NPR5.29/BHR/20161026 CASE 248684 Add fields "Sell to contact Mandatory","Email Mandatory","Phone Mandatory"
    layout
    {
        addafter(Description)
        {
            field("Service Demand"; "Service Demand")
            {
                ApplicationArea = All;
            }
            field("Notification Service"; "Notification Service")
            {
                ApplicationArea = All;
            }
            field("Default Option"; "Default Option")
            {
                ApplicationArea = All;
            }
        }
        addafter(CustomizedCalendar)
        {
            field("Email Mandatory"; "Email Mandatory")
            {
                ApplicationArea = All;
            }
            field("Phone Mandatory"; "Phone Mandatory")
            {
                ApplicationArea = All;
            }
        }
    }
}

