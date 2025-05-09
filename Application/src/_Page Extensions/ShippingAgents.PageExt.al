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
#if not BC17
            field("NPR Spfy Tracking Company"; Rec."NPR Spfy Tracking Company")
            {
                ToolTip = 'Specifies the name under which the shipping agent is registered as a tracking company with Shopify. If you cannot find the value you need, select "Other" and then use the "Shipping Agent Name" field to specify your tracking company name. Enter the tracking company name exactly as Shopify lists it (capitalization matters).';
                ApplicationArea = NPRShopify;
            }
#endif
        }
    }
}