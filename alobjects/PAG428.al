pageextension 70000247 pageextension70000247 extends "Shipping Agents" 
{
    // PS1.00/LS/20141201  CASE 200150 : Added fields "Shipping Agent Demand" & "Pacsoft Product"
    // NPR5.25/MMV /20160621 CASE 233533 Added field 6014442
    // NPR5.29/BHR/20161028 CASE 248684 Added fields "Shipping Method","Sell to contact Mandatory","Drop Point Service"
    // NPR5.43/BHR/20180508 CASE 304453 Add field "Return Shipping agent"
    Caption = 'Shipping Agents';
    layout
    {
        addafter(Name)
        {
            field("Shipping Method";"Shipping Method")
            {
            }
            field("Ship to Contact Mandatory";"Ship to Contact Mandatory")
            {
            }
            field("Drop Point Service";"Drop Point Service")
            {
            }
        }
        addafter("Account No.")
        {
            field("Shipping Agent Demand";"Shipping Agent Demand")
            {
            }
            field("Pacsoft Product";"Pacsoft Product")
            {
            }
            field("Custom Print Layout";"Custom Print Layout")
            {
            }
            field("Return Shipping agent";"Return Shipping agent")
            {
            }
        }
    }
    actions
    {
        modify("&Line")
        {
            Caption = '&Line';
        }
        modify(ShippingAgentServices)
        {

            //Unsupported feature: Property Modification (Name) on "ShippingAgentServices(Action 14)".

            Caption = 'Shipping A&gent Services';
        }
    }
}

