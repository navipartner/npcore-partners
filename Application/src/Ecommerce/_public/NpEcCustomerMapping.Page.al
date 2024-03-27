page 6151305 "NPR NpEc Customer Mapping"
{
    Extensible = true;
    Caption = 'Np E-commerce Customer Mapping';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpEc Customer Mapping";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies E-Commerce Store Code.';
                    ApplicationArea = NPRRetail;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the customer''s country/region.';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ToolTip = 'Specifies the postal code.';
                    ApplicationArea = NPRRetail;
                }
                field("Config. Template Code"; Rec."Config. Template Code")
                {
                    ToolTip = 'Specifies Configuration Template Code.';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Spfy Customer No."; Rec."Spfy Customer No.")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Shopify: specifies a predefined customer that will be used by default for imported Shopify orders if a specific customer can’t be found. Alternatively, you can set a predefined customer on the E-commerce Store Card. Click "Learn more" for more details on the customer search routine.';
                }
#endif
                field("Country/Region Name"; Rec."Country/Region Name")
                {
                    ToolTip = 'Specifies the country or region name.';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the city of the customer.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
