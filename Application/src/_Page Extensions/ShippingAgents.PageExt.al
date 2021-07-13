pageextension 6014441 "NPR Shipping Agents" extends "Shipping Agents"
{
    Caption = 'Shipping Agents';
    layout
    {
        addafter("Account No.")
        {
            field("NPR Shipping Agent Demand"; Rec."NPR Shipping Agent Demand")
            {

                ToolTip = 'Specifies the value of the NPR Shipping Agent Demand field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Pacsoft Product"; Rec."NPR Pacsoft Product")
            {

                ToolTip = 'Specifies the value of the NPR Pacsoft Product field';
                ApplicationArea = NPRRetail;
            }
            field("NPR Custom Print Layout"; Rec."NPR Custom Print Layout")
            {

                ToolTip = 'Specifies the value of the NPR Custom Print Layout field';
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