page 6150648 "NPR POS Pricing Profiles"
{
    Extensible = False;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Pricing Profile";
    Caption = 'POS Pricing Profiles';
    ContextSensitiveHelpPage = 'docs/retail/pos_profiles/how-to/pricing_profile/pricing_profile/';
    Editable = false;
    CardPageID = "NPR POS Pricing Profile Card";
    ApplicationArea = NPRRetail;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the unique identifier or code for the price profile. This code helps you easily reference and manage different pricing configurations.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies descriptive name or title for the price profile. This helps users understand the purpose or context of the pricing setup.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Disc. Group"; Rec."Customer Disc. Group")
                {
                    ToolTip = 'Specifies customer groups assigned to this price profile in order to apply customized discounts based on group membership.';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Price Group"; Rec."Customer Price Group")
                {
                    ToolTip = 'Specifies the link from this price profile to a specific customer price group, allowing tailored pricing for different customer segments.';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Codeunit ID"; Rec."Item Price Codeunit ID")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Codeunit Name"; Rec."Item Price Codeunit Name")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Item Price Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Price Function"; Rec."Item Price Function")
                {
                    ToolTip = 'Specifies the function for subscribing to a custom event that calculates the item price in a particular way. The price will be dictated by a specified codeunit.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
