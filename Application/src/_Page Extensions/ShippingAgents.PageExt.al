pageextension 6014441 "NPR Shipping Agents" extends "Shipping Agents"
{
    Caption = 'Shipping Agents';
    layout
    {
        addafter(Name)
        {
            field("NPR Shipping Method"; Rec."NPR Shipping Method")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Shipping Method field';
            }
            field("NPR Ship to Contact Mandatory"; Rec."NPR Ship to Contact Mandatory")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Ship to Contact Mandatory field';
            }
            field("NPR Drop Point Service"; Rec."NPR Drop Point Service")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NPR Drop Point Service field';
            }
        }
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
            field("NPR Return Shipping agent"; Rec."NPR Return Shipping agent")
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
            Caption = 'Shipping A&gent Services';
        }
    }
}