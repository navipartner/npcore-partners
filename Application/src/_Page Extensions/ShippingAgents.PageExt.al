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
                ToolTip = 'Specifies the value of the NPR Shipping Method field';
            }
            field("NPR Ship to Contact Mandatory"; "NPR Ship to Contact Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Ship to Contact Mandatory field';
            }
            field("NPR Drop Point Service"; "NPR Drop Point Service")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Drop Point Service field';
            }
        }
        addafter("Account No.")
        {
            field("NPR Shipping Agent Demand"; "NPR Shipping Agent Demand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Shipping Agent Demand field';
            }
            field("NPR Pacsoft Product"; "NPR Pacsoft Product")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pacsoft Product field';
            }
            field("NPR Custom Print Layout"; "NPR Custom Print Layout")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Custom Print Layout field';
            }
            field("NPR Return Shipping agent"; "NPR Return Shipping agent")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Return Shipping agent field';
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

