#if not BC17
page 6248200 "NPR Spfy Inv. Item Locations"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Inventory Item Locations';
    PageType = List;
    SourceTable = "NPR Spfy Inv Item Location";
    UsageCategory = Administration;
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store for which location is activated.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Location ID"; Rec."Shopify Location ID")
                {
                    ToolTip = 'Specifies the Shopify location ID where your items are handled and stored before being sold.';
                    ApplicationArea = NPRShopify;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of Item No. field.';
                    ApplicationArea = NPRShopify;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of Variant Code field.';
                    ApplicationArea = NPRShopify;
                }
                field(Activated; Rec.Activated)
                {
                    ToolTip = 'Specifies whether the location is activated in the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif