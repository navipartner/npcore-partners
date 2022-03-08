pageextension 6014441 "NPR Shipping Agents" extends "Shipping Agents"
{
    Caption = 'Shipping Agents';
    layout
    {
        addafter("Account No.")
        {
            field("NPR Shipping Agent Demand"; Rec."NPR Shipping Agent Demand")
            {

                ToolTip = 'Enable choosing the Shipping Agent Demand by selecting a service or custom information.';
                ApplicationArea = NPRRetail;
            }
            field("NPR Custom Print Layout"; Rec."NPR Custom Print Layout")
            {

                ToolTip = 'Enable specifying a custom print layout to be used.';
                ApplicationArea = NPRRetail;
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
            Caption = 'Shipping A&gent Services';
        }
    }
}