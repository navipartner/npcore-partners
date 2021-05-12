pageextension 6014441 "NPR Shipping Agents" extends "Shipping Agents"
{
    Caption = 'Shipping Agents';
    layout
    {
        addafter("Account No.")
        {
            field("NPR Shipping Agent Demand"; Rec."NPR Shipping Agent Demand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Shipping Agent Demand field';
            }
            field("NPR Pacsoft Product"; Rec."NPR Pacsoft Product")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Pacsoft Product field';
            }
            field("NPR Custom Print Layout"; Rec."NPR Custom Print Layout")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Custom Print Layout field';
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