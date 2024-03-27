#if not BC17
page 6184554 "NPR Spfy Location Mapping"
{
    Extensible = false;
    PageType = List;
    SourceTable = "NPR Spfy Location Mapping";
    Caption = 'Location Mapping';
    UsageCategory = None;
    DelayedInsert = true;
    ContextSensitiveHelpPage = 'salesordersetup.html#set-up-location-mapping';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Store Code"; Rec."Store Code")
                {
                    ToolTip = 'Specifies the Shopify store code (e-commerce store in BC).';
                    ApplicationArea = NPRShopify;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code the current setup line is applicable for.';
                    ApplicationArea = NPRShopify;
                }
                field("From Post Code"; Rec."From Post Code")
                {
                    ToolTip = 'Specifies the beginning of a range of post codes the current setup line is applicable for.';
                    ApplicationArea = NPRShopify;
                }
                field("To Post Code"; Rec."To Post Code")
                {
                    ToolTip = 'Specifies the end of a range of post codes the current setup line is applicable for.';
                    ApplicationArea = NPRShopify;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies a location code items are shipped from for imported Sales Orders.';
                    ApplicationArea = NPRShopify;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies a shipping agent assigned to the Sales Orders.';
                    ApplicationArea = NPRShopify;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ToolTip = 'Specifies a shipping agent service code assigned to the Sales Orders.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif