pageextension 50061 pageextension50061 extends "Shipping Agent Services" 
{
    // PS1.00/LS/20141201  CASE 200150 Fields "Service Demand", "Notification Service", "Default Option"
    // NPR5.29/BHR/20161026 CASE 248684 Add fields "Sell to contact Mandatory","Email Mandatory","Phone Mandatory"
    layout
    {
        addafter(Description)
        {
            field("Service Demand";"Service Demand")
            {
            }
            field("Notification Service";"Notification Service")
            {
            }
            field("Default Option";"Default Option")
            {
            }
        }
        addafter(CustomizedCalendar)
        {
            field("Email Mandatory";"Email Mandatory")
            {
            }
            field("Phone Mandatory";"Phone Mandatory")
            {
            }
        }
    }
}

