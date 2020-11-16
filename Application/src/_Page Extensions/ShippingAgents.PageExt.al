pageextension 6014441 "NPR Shipping Agents" extends "Shipping Agents"
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
            field("NPR Shipping Method"; "NPR Shipping Method")
            {
                ApplicationArea = All;
            }
            field("NPR Ship to Contact Mandatory"; "NPR Ship to Contact Mandatory")
            {
                ApplicationArea = All;
            }
            field("NPR Drop Point Service"; "NPR Drop Point Service")
            {
                ApplicationArea = All;
            }
        }
        addafter("Account No.")
        {
            field("NPR Shipping Agent Demand"; "NPR Shipping Agent Demand")
            {
                ApplicationArea = All;
            }
            field("NPR Pacsoft Product"; "NPR Pacsoft Product")
            {
                ApplicationArea = All;
            }
            field("NPR Custom Print Layout"; "NPR Custom Print Layout")
            {
                ApplicationArea = All;
            }
            field("NPR Return Shipping agent"; "NPR Return Shipping agent")
            {
                ApplicationArea = All;
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

